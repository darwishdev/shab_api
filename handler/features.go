package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) FeaturesListByRole(c echo.Context) error {
	var role *int
	if c.QueryParam("Role_id") != "" {
		r, _ := strconv.Atoi(c.QueryParam("Role_id"))
		role = &r
	}
	features, err := h.roleRepo.ListFeaturesByRole(role, c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, features)
}

func (h *Handler) FeaturesDownloadExcel(c echo.Context) error {
	var role *int
	if c.QueryParam("Role_id") != "" {
		r, _ := strconv.Atoi(c.QueryParam("Role_id"))
		role = &r
	}
	features, err := h.roleRepo.ListFeaturesByRole(role, c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	file := utils.GenerateExcel(*features)
	return c.JSON(http.StatusOK, file)
}

func (h *Handler) FeaturesFindById(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	features, err := h.roleRepo.FindFeatureById(&id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, features)
}

func (h *Handler) FeaturesEditAdd(c echo.Context) error {
	r := new(model.Feature)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	id, _ := strconv.Atoi(c.Param("id"))
	r.Id = id
	features, err := h.roleRepo.EditAddFeature(r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, features)
}
