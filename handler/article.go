package handler

import (
	"fmt"
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) ArticleListByCategoryUserSearch(c echo.Context) error {
	req := new(model.ArticlesListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	articles, err := h.articleRepo.ListByCategoryUserSearch(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, articles)
}

func (h *Handler) ArticlesDownloadExcel(c echo.Context) error {
	req := new(model.ArticlesListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	articles, err := h.articleRepo.ListByCategoryUserSearch(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	file := utils.GenerateExcel(*articles)
	return c.JSON(http.StatusOK, file)
}

func (h *Handler) ArticleDelete(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		fmt.Println(err)
	}
	article, err := h.articleRepo.ArticleDelete(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, article)
}
func (h *Handler) ArticleRead(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		fmt.Println(err)
	}
	article, err := h.articleRepo.ArticleRead(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, article)
}

// func (h *Handler) ArticleUpdate(c echo.Context) error {
// 	id, _ := strconv.Atoi(c.Param("id"))

// 	r := new(model.ProjectCreateReq)
// 	if err := c.Bind(r); err != nil {
// 		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
// 	}
// 	resp, err := h.articleRepo.ArticleUpdate(r, &id)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
// 	}
// 	return c.JSON(http.StatusOK, resp)
// }

func (h *Handler) ArticleCreate(c echo.Context) error {
	r := new(model.ArticleCreateReq)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r.UserId = userIDFromToken(c)
	resp, err := h.articleRepo.ArticleCreate(r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, resp)
}

func (h *Handler) ArticleUpdate(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	r := new(model.ArticleCreateReq)
	if err := c.Bind(r); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	r.UserId = userIDFromToken(c)
	resp, err := h.articleRepo.ArticleUpdate(&id, r)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, resp)
}

// func (h *Handler) ArticleCreate(c echo.Context) error {
// 	// upload image
// 	img, err := c.FormFile("Img")
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, "img_required"+err.Error())
// 	}
// 	imgName, err := utils.Upload(img)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, "err_uploading_img"+err.Error())
// 	}

// 	req := ScanArticleCreateReq(c, imgName)
// 	article, err := h.articleRepo.ArticleCreate(req)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
// 	}
// 	n := &model.Notification{
// 		Title: "طلب اضافة مقال",
// 		Breif: fmt.Sprintf("يوجد طلب اضافة مقال جديد باسم %s", req.Title),
// 		Link:  fmt.Sprintf("users/articels/%d", article),
// 	}

// 	_, err = h.notificationRepo.Create(n)
// 	return c.JSON(http.StatusOK, article)
// }

// func ScanArticleCreateReq(c echo.Context, img string) model.ArticleCreateReq {
// 	id := userIDFromToken(c)
// 	req := new(model.ArticleCreateReq)
// 	req.UserId = id
// 	req.CategoryId, _ = strconv.ParseUint(c.FormValue("CategoryId"), 0, 8)
// 	req.Img = img
// 	req.Title = c.FormValue("Title")
// 	req.Content = c.FormValue("Content")
// 	return *req

// }
