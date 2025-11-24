package main

import (
	"fmt"
	"log/slog"
	"os"
	"runtime"
	"strings"

	"github.com/pkg/errors"
)

type stackTracer interface {
	StackTrace() errors.StackTrace
}

const moduleName = "github.com/testdotcom"

func formatStackTrace(stackTrace errors.StackTrace) []string {
	var frames []string

	for _, frame := range stackTrace {
		pc := uintptr(frame) - 1
		fn := runtime.FuncForPC(pc)

		if fn == nil {
			frames = append(frames, "unknown")

			continue
		}

		if strings.HasPrefix(fn.Name(), moduleName) {
			file, line := fn.FileLine(pc)
			frames = append(frames, fmt.Sprintf("%s:%d %s", file, line, fn.Name()))
		}
	}

	return frames
}

func replaceAttr(groups []string, a slog.Attr) slog.Attr {
	if a.Key == "error" {
		if err, ok := a.Value.Any().(error); ok {
			if st, ok := err.(stackTracer); ok {
				stack := st.StackTrace()

				return slog.Group("error",
					slog.String("msg", err.Error()),
					slog.Any("stack", formatStackTrace(stack)),
				)
			}
		}
	}

	return a
}

func InitLogger(level string) {
	slogLevel := slog.LevelInfo

	switch level {
	case "debug":
		slogLevel = slog.LevelDebug
	case "warn":
		slogLevel = slog.LevelWarn
	case "error":
		slogLevel = slog.LevelError
	default:
	}

	opts := &slog.HandlerOptions{
		Level:       slogLevel,
		AddSource:   true,
		ReplaceAttr: replaceAttr,
	}

	var logHandler slog.Handler = slog.NewJSONHandler(os.Stdout, opts)
	if slogLevel == slog.LevelDebug {
		logHandler = slog.NewTextHandler(os.Stdout, opts)
	}

	logger := slog.New(logHandler)
	slog.SetDefault(logger)
}
