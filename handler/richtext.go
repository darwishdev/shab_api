package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) RichDownloadExcel(c echo.Context) error {
	title := c.QueryParam("Title")
	value := c.QueryParam("Value")
	r, err := h.richTextRepo.ListByPage("home", title, value)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}
func (h *Handler) RichListByPage(c echo.Context) error {
	title := c.QueryParam("Title")
	value := c.QueryParam("Value")
	r, err := h.richTextRepo.ListByPage("home", title, value)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) RichListByGroup(c echo.Context) error {

	r, err := h.richTextRepo.ListByGroup(1)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) RichGetById(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	r, err := h.richTextRepo.GetById(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) RichUpdate(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	req := new(model.RichText)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.richTextRepo.Update(&id, req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) RichGetByKey(c echo.Context) error {

	r, err := h.richTextRepo.GetByKey("banner")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}
