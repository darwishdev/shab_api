package utils

import (
	"io"
	"mime/multipart"
	"os"
	"time"
)

func Upload(file *multipart.FileHeader) (string, error) {
	currentTime := time.Now()
	src, err := file.Open()
	if err != nil {
		return "", err
	}
	defer src.Close()

	fileName := "assets/" + currentTime.String() + file.Filename
	// Destination
	dst, err := os.Create(fileName)
	if err != nil {
		return "", err
	}
	defer dst.Close()

	// Copy
	if _, err = io.Copy(dst, src); err != nil {
		return "", err
	}

	return fileName, nil
}
