package logger

import (
	"log"
	"os"
)

var (
	Info  *log.Logger
	Warn  *log.Logger
	Error *log.Logger
	Fatal *log.Logger
)

// Init 初始化日志
func Init(level string) {
	flags := log.LstdFlags | log.Lshortfile

	switch level {
	case "debug":
		Info = log.New(os.Stdout, "INFO: ", flags)
		Warn = log.New(os.Stdout, "WARN: ", flags)
		Error = log.New(os.Stderr, "ERROR: ", flags)
		Fatal = log.New(os.Stderr, "FATAL: ", flags)
	case "info":
		Info = log.New(os.Stdout, "INFO: ", flags)
		Warn = log.New(os.Stdout, "WARN: ", flags)
		Error = log.New(os.Stderr, "ERROR: ", flags)
		Fatal = log.New(os.Stderr, "FATAL: ", flags)
	case "warn":
		Info = log.New(os.Stdout, "INFO: ", flags)
		Warn = log.New(os.Stdout, "WARN: ", flags)
		Error = log.New(os.Stderr, "ERROR: ", flags)
		Fatal = log.New(os.Stderr, "FATAL: ", flags)
	case "error":
		Info = log.New(os.Stdout, "INFO: ", flags)
		Warn = log.New(os.Stdout, "WARN: ", flags)
		Error = log.New(os.Stderr, "ERROR: ", flags)
		Fatal = log.New(os.Stderr, "FATAL: ", flags)
	default:
		Info = log.New(os.Stdout, "INFO: ", flags)
		Warn = log.New(os.Stdout, "WARN: ", flags)
		Error = log.New(os.Stderr, "ERROR: ", flags)
		Fatal = log.New(os.Stderr, "FATAL: ", flags)
	}
}
