package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) RolesDownloadExcel(c echo.Context) error {
	var active *bool
	var priceFrom int
	var priceTo int
	if c.QueryParam("active") != "" {
		filter, _ := strconv.ParseBool(c.QueryParam("active"))
		active = &filter
	}
	if c.QueryParam("PriceFrom") != "" {
		priceFrom, _ = strconv.Atoi(c.QueryParam("PriceFrom"))
	}
	if c.QueryParam("PriceTo") != "" {
		priceTo, _ = strconv.Atoi(c.QueryParam("PriceTo"))
	}

	r, err := h.roleRepo.ListAll(active, priceFrom, priceTo, c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}
func (h *Handler) RolesListAll(c echo.Context) error {
	var active *bool
	var priceFrom int
	var priceTo int
	if c.QueryParam("active") != "" {
		filter, _ := strconv.ParseBool(c.QueryParam("active"))
		active = &filter
	}
	if c.QueryParam("PriceFrom") != "" {
		priceFrom, _ = strconv.Atoi(c.QueryParam("PriceFrom"))
	}
	if c.QueryParam("PriceTo") != "" {
		priceTo, _ = strconv.Atoi(c.QueryParam("PriceTo"))
	}

	r, err := h.roleRepo.ListAll(active, priceFrom, priceTo, c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) RolesFind(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	r, err := h.roleRepo.Find(&id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) RolesEdit(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))

	r := new(model.Role)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	resp, err := h.roleRepo.Edit(&id, r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, resp)
}
