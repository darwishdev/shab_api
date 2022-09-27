package handler

import (
	"net/http"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) DeleteRecord(c echo.Context) error {
	tableName := c.Param("table")
	id, _ := strconv.Atoi(c.Param("id"))
	r, err := h.globalRepo.Delete(&tableName, &id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}
