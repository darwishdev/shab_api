package handler

import (
	"fmt"
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) EventsListAll(c echo.Context) error {
	r := new(model.EventListReq)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	fmt.Println(r)
	events, err := h.eventRepo.ListAll(r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, events)
}

func (h *Handler) EventsDownloadExcel(c echo.Context) error {
	r := new(model.EventListReq)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	events, err := h.eventRepo.ListAll(r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(*events)
	return c.JSON(http.StatusOK, file)
}

func (h *Handler) EventRead(c echo.Context) error {
	id, _ := strconv.ParseInt(c.Param("id"), 10, 64)
	events, err := h.eventRepo.Read(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, events)
}

func (h *Handler) EventUpdate(c echo.Context) error {
	fmt.Println("asdasd")
	id, _ := strconv.Atoi(c.Param("id"))
	r := new(model.EventRequest)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	events, err := h.eventRepo.Edit(&id, r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, events)
}

func (h *Handler) EventCreate(c echo.Context) error {
	r := new(model.EventRequest)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	events, err := h.eventRepo.Create(r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, events)
}
