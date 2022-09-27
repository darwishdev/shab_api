package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) ServicesDownloadExcel(c echo.Context) error {
	services, err := h.serviceRepo.ListAllServicces(c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(*services)
	return c.JSON(http.StatusOK, file)
}
func (h *Handler) ServicesListAll(c echo.Context) error {
	services, err := h.serviceRepo.ListAllServicces(c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, services)
}

func (h *Handler) ServicesFindById(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	services, err := h.serviceRepo.Find(&id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, services)
}

func (h *Handler) ServiceCreate(c echo.Context) error {
	req := new(model.Service)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	services, err := h.serviceRepo.CreateService(*req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, services)
}
func (h *Handler) ServiceUpdate(c echo.Context) error {
	req := new(model.Service)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	req.Id, _ = strconv.Atoi(c.Param("id"))

	services, err := h.serviceRepo.UpdateService(*req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, services)
}

func (h *Handler) ServiceDelete(c echo.Context) error {
	services, err := h.serviceRepo.DeleteService(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, services)
}
