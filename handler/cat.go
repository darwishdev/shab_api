package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) CatsListByType(c echo.Context) error {
	r, err := h.catRepo.CatListByType(c.QueryParam("type"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) CatRead(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	r, err := h.catRepo.CatRead(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) CatCreate(c echo.Context) error {
	req := new(model.Cat)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.catRepo.CatCreate(*req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) CatUpdate(c echo.Context) error {
	req := new(model.Cat)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.catRepo.CatUpdate(*req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}
