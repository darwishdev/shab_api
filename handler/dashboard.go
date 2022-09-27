package handler

import (
	"net/http"
	"shab/utils"

	"github.com/labstack/echo/v4"
)

func (h *Handler) FindDashboardCounts(c echo.Context) error {
	resp, err := h.reportsRepo.GetCounts()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	resp.Visitors = 1200
	return c.JSON(http.StatusOK, resp)
}
