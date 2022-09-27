package handler

import (
	"fmt"
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) MsgsListAll(c echo.Context) error {
	id := userIDFromToken(c)
	msgs, err := h.msgRepo.ListAll(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, msgs)
}

func (h *Handler) MsgsListByUser(c echo.Context) error {
	from_id := userIDFromToken(c)
	to_id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		fmt.Println(err)
	}
	resp, err := h.msgRepo.ListByUser(from_id, to_id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, resp)
}
func (h *Handler) MsgsCreate(c echo.Context) error {
	id := userIDFromToken(c)
	req := new(model.MsgReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	req.FromId = id
	msg, err := h.msgRepo.Create(*req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, msg)
}
