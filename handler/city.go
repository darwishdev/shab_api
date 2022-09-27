package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) CitiesList(c echo.Context) error {
	r, err := h.cityRepo.CityListAll()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}
func (h *Handler) CityRead(c echo.Context) error {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	r, err := h.cityRepo.CityRead(&id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) CityCreate(c echo.Context) error {
	req := new(model.City)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.cityRepo.CityCreate(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) CityUpdate(c echo.Context) error {
	req := new(model.City)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	req.Id, _ = strconv.ParseUint(c.Param("id"), 10, 32)
	r, err := h.cityRepo.CityUpdate(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}
