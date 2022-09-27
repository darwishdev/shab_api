package handler

import (
	"fmt"
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) ConsultuntsListAll(c echo.Context) error {
	req := new(model.ConsultuntListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	consultunts, err := h.consltuntsRepo.ConsultuntsListAll(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, consultunts)
}

func (h *Handler) TeamList(c echo.Context) error {
	req := new(model.ConsultuntListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	req.IsTeam = true
	consultunts, err := h.consltuntsRepo.ConsultuntsListAll(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, consultunts)
}

func (h *Handler) TeamDownloadExcel(c echo.Context) error {
	req := new(model.ConsultuntListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	req.IsTeam = true
	consultunts, err := h.consltuntsRepo.ConsultuntsListAll(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	fileName := utils.GenerateExcel(consultunts)
	return c.JSON(http.StatusOK, fileName)
}

func (h *Handler) ConsultuntsCreate(c echo.Context) error {
	req := new(model.Consultunt)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	req.Skills = fmt.Sprintf("%s,%s,%s", req.Skills1, req.Skills2, req.Skills3)

	u, err := h.consltuntsRepo.ConsultuntsCreate(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}

func (h *Handler) ConsultuntsDownloadExcel(c echo.Context) error {
	req := new(model.ConsultuntListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	consultunts, err := h.consltuntsRepo.ConsultuntsListAll(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	fileName := utils.GenerateExcel(consultunts)
	fmt.Println(fileName)

	return c.JSON(http.StatusOK, fileName)

	// return c.JSON(http.StatusOK, users)
}
func (h *Handler) ConsultuntsUpdate(c echo.Context) error {
	fmt.Println("hellow wo")
	req := new(model.Consultunt)
	var err error
	req.Id, err = strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	if err = c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	req.Skills = req.Skills1
	if req.Skills2 != "" {
		req.Skills += "," + req.Skills2
	}
	if req.Skills3 != "" {
		req.Skills += "," + req.Skills3
	}
	u, err := h.consltuntsRepo.ConsultuntsUpdate(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}
func (h *Handler) ConsultuntById(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	consultunt, err := h.consltuntsRepo.ConsultuntById(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, consultunt)
}
