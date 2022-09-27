package handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

func (h *Handler) CheckHealth(c echo.Context) error {
	return c.JSON(http.StatusOK, "website works fine")
}
