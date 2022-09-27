package handler

import (
	"fmt"
	"net/http"
	"shab/model"
	"shab/utils"

	"github.com/labstack/echo/v4"
)

func (h *Handler) ContactSend(c echo.Context) error {
	req := new(model.ContactSendReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	n := &model.Notification{
		Title: fmt.Sprintf("رسالة جديدة من  %s ", req.Name),
		Breif: req.Breif,
		Link:  fmt.Sprintf("contact/%d", 1),
	}

	_, err := h.notificationRepo.Create(n)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	// u, err := h.consltuntsRepo.ConsultuntsCreate(req)
	// if err != nil {
	// 	return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	// }
	return c.JSON(http.StatusOK, "u")
}

func (h *Handler) ContactsPendingListAll(c echo.Context) error {
	req := new(model.ContactListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListContactRequests(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ContactsRequestsDownloadExcel(c echo.Context) error {
	req := new(model.ContactListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListContactRequests(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}
