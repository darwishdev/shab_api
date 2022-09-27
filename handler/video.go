package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) VideosFind(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	r, err := h.videoRepo.Find(&id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) VideosDownloadExcel(c echo.Context) error {
	var cat int
	var err error
	if c.QueryParam("CatId") != "" {
		cat, err = strconv.Atoi(c.QueryParam("CatId"))
		if err != nil {
			return c.JSON(http.StatusInternalServerError, utils.NewError(err))
		}

	}
	r, err := h.videoRepo.ListByCategory(cat, c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}
func (h *Handler) VideosListByCategory(c echo.Context) error {
	var cat int
	var err error
	if c.QueryParam("CatId") != "" {
		cat, err = strconv.Atoi(c.QueryParam("CatId"))
		if err != nil {
			return c.JSON(http.StatusInternalServerError, utils.NewError(err))
		}

	}
	r, err := h.videoRepo.ListByCategory(cat, c.QueryParam("Name"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) VideosCreate(c echo.Context) error {
	req := new(model.VideoCreateReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.videoRepo.Create(*req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) VideosUpdate(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	req := new(model.Video)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	req.Id = id
	r, err := h.videoRepo.Update(*req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) VideosDelete(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	r, err := h.videoRepo.Delete(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}
