package handler

import (
	"fmt"
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

var content string

func (h *Handler) ServicesPendingListAll(c echo.Context) error {
	req := new(model.ServicePendingReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingServices(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ServicesRequestsDownloadExcel(c echo.Context) error {
	req := new(model.ServicePendingReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingServices(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}

func (h *Handler) UsersPendingListAll(c echo.Context) error {
	req := new(model.PendingUsersListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingUsers(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ArticlesPendingUploadExcel(c echo.Context) error {
	data, err := utils.ReadExcel(c.QueryParam("file"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	for _, v := range data {
		if v[0] == "" {
			return c.JSON(http.StatusOK, "file")

		}
		req := new(model.ArticleCreateReq)
		req.Title = v[0]
		req.Img = v[1]
		req.CatId, _ = strconv.ParseUint(v[2], 10, 32)
		s, _ := strconv.ParseUint(v[3], 10, 32)
		t := uint(s)
		req.UserId = t
		req.Content = generateArticleContent(v, 0)
		req.Status = "pending"
		// req.Role_id = v[7]
		// req.City_id = v[8]
		// req.Breif = v[9]
		// req.Admin = v[10]

		_, err := h.articleRepo.ArticleCreate(req)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, utils.NewError(err))
		}
	}
	return c.JSON(http.StatusOK, "file")
}
func generateArticleContent(v []string, i int) string {

	currentCol := v[i]
	if currentCol == "" || i == len(v) {
		return content

	}
	if i%2 == 0 {
		content += fmt.Sprintf("<h2>%s</h2><br />", currentCol)
	} else {
		content += fmt.Sprintf("<p>%s</p> <br />", currentCol)
	}
	generateArticleContent(v, i+1)
	return content
}
func (h *Handler) UsersPendingUploadExcel(c echo.Context) error {
	data, err := utils.ReadExcel(c.QueryParam("file"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	for _, v := range data {
		if v[0] == "" {
			return c.JSON(http.StatusOK, "file")

		}

		req := new(model.UserRegisterRequest)
		req.Name = v[0]
		req.Name_ar = v[1]
		req.Email = v[2]
		req.Phone = v[3]
		req.Breif = v[4]
		req.Role_id, _ = strconv.ParseUint(v[5], 10, 32)
		req.City_id, _ = strconv.ParseUint(v[6], 10, 32)
		// req.Role_id = v[7]
		// req.City_id = v[8]
		// req.Breif = v[9]
		// req.Admin = v[10]

		_, err := h.userRepo.Register(req)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, utils.NewError(err))
		}
	}
	return c.JSON(http.StatusOK, "file")
}
func (h *Handler) UsersRequestsDownloadExcel(c echo.Context) error {
	req := new(model.PendingUsersListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingUsers(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}
func (h *Handler) UsersPendingUpgradeListAll(c echo.Context) error {
	req := new(model.UsersUpgratedListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingUpgrades(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) UsersUpgradesDownloadExcel(c echo.Context) error {
	req := new(model.UsersUpgratedListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingUpgrades(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}

func (h *Handler) ProjectsPendingListAll(c echo.Context) error {
	req := new(model.ProjectsPendingListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingProjects(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ProjectsRequestsDownloadExcel(c echo.Context) error {
	req := new(model.ProjectsPendingListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingProjects(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(*r)

	return c.JSON(http.StatusOK, file)
}

func (h *Handler) ArticlesPendingListAll(c echo.Context) error {
	req := new(model.ProjectsPendingListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingArticles(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ArticleRequestsDownloadExcel(c echo.Context) error {
	req := new(model.ProjectsPendingListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r, err := h.requestRepo.ListPendingArticles(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(*r)
	return c.JSON(http.StatusOK, file)
}
func (h *Handler) ServicesPendingFind(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	r, err := h.serviceRepo.FindPendingSerivce(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ServicesPendingAction(c echo.Context) error {
	action := c.Param("action")
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	// if err := c.Bind(req); err != nil {
	// 	return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	// }

	r, err := h.requestRepo.ApprovePendingService(&id, &action)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	req := model.MsgReq{FromId: 1, ToId: id, Msg: "تم قبول طلب الخدمة و سيتم التواصل معك "}
	r, err = h.userRepo.SendMsg(&req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	return c.JSON(http.StatusOK, r)
}

func (h *Handler) UsersPendingAction(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	action := c.Param("action")

	r, err := h.requestRepo.PendingUserAction(&id, &action)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) UsersUpgradeApprove(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	r, err := h.requestRepo.ApproveUserUpgrade(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ProjectsPendingAction(c echo.Context) error {
	action := c.Param("action")
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	r, err := h.requestRepo.PendingProjectAction(&id, &action)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}

func (h *Handler) ArticlesPendingAction(c echo.Context) error {
	action := c.Param("action")
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	r, err := h.requestRepo.ApprovePendingArticle(&id, &action)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, r)
}
