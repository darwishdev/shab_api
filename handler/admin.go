package handler

import (
	"net/http"
	"shab/model"
	"shab/utils"

	"github.com/labstack/echo/v4"
)

func list(c echo.Context, h *Handler) ([]interface{}, error) {
	req := new(model.UserListReq)
	if err := c.Bind(req); err != nil {
		return nil, err
	}
	req.Admin = true
	users, err := h.userRepo.ListByRoleOrFeatured(req)
	// users, err := h.userRepo.ListAll()
	if err != nil {
		return nil, err
	}

	return users, nil
}
func (h *Handler) AdminsList(c echo.Context) error {
	admins, err := list(c, h)
	if err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, admins)
}

func (h *Handler) AdminsDownloadExcel(c echo.Context) error {
	admins, err := list(c, h)
	if err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	file := utils.GenerateExcel(admins)
	return c.JSON(http.StatusOK, file)

	// return c.JSON(http.StatusOK, users)
}
