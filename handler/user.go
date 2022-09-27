package handler

import (
	"fmt"
	"net/http"
	"shab/model"
	"shab/utils"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (h *Handler) ValidateUser(c echo.Context) error {
	return c.JSON(http.StatusOK, true)
}

func (h *Handler) CurrentUserNotifications(c echo.Context) error {
	id := userIDFromToken(c)
	u, err := h.userRepo.GetNotificationsById(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}

func (h *Handler) Me(c echo.Context) error {
	id := userIDFromToken(c)
	u, err := h.userRepo.GetById(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}
func (h *Handler) CurrentUserMessages(c echo.Context) error {
	id := userIDFromToken(c)

	u, err := h.msgRepo.ListByUser(1, uint64(id))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}

func (h *Handler) CurrentUserUpgradeRequests(c echo.Context) error {
	id := userIDFromToken(c)
	u, err := h.requestRepo.FindUserUpgradeRequest(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}

func (h *Handler) UserUpgrade(c echo.Context) error {
	id := userIDFromToken(c)
	role, err := strconv.ParseUint(c.Param("role"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	u, err := h.userRepo.Upgradeuser(id, role)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}
func (h *Handler) UserFindById(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	u, err := h.userRepo.GetById(uint(id))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}

func (h *Handler) UserRequestService(c echo.Context) error {
	req := new(model.UserServiceRequest)
	var err error
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	req.User = userIDFromToken(c)
	req.Service, err = strconv.ParseUint(c.Param("id"), 10, 32)

	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	u, err := h.requestRepo.RequestService(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	n := &model.Notification{
		Title: "طلب خدمة",
		Breif: req.Breif,
		Link:  fmt.Sprintf("users/services/%d", *u),
	}

	_, err = h.notificationRepo.Create(n)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}
func (h *Handler) UserListRyadeen(c echo.Context) error {
	users, err := h.userRepo.ListRyadeen()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, users)
}

func (h *Handler) UserListAll(c echo.Context) error {
	users, err := h.userRepo.ListAll()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, users)
}

func (h *Handler) UsersDownloadExcel(c echo.Context) error {

	req := new(model.UserListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	users, err := h.userRepo.ListByRoleOrFeatured(req)

	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	file := utils.GenerateExcel(users)
	return c.JSON(http.StatusOK, file)

	// return c.JSON(http.StatusOK, users)
}
func (h *Handler) UserListByRoleOrFeatured(c echo.Context) error {
	req := new(model.UserListReq)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	users, err := h.userRepo.ListByRoleOrFeatured(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, users)
}

func (h *Handler) RegisterUser(c echo.Context) error {
	req := new(model.UserRegisterRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	if req.Name_ar == "" {
		req.Name_ar = req.Name
	}
	u, err := h.userRepo.Register(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	n := &model.Notification{
		Title: "طلب عضوية",
		Breif: fmt.Sprintf("طلب عضوية  من قبل %s", req.Name_ar),
		Link:  fmt.Sprintf("users/approve/%d", *u),
	}

	_, err = h.notificationRepo.Create(n)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}

func (h *Handler) CurrentUserUpdate(c echo.Context) error {
	id := userIDFromToken(c)
	req := new(model.UserRegisterRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	_, err := h.userRepo.Update(id, req)
	if req.Img != "" {
		n := &model.Notification{
			Title: "طلب تغير صورة",
			Breif: fmt.Sprintf("طلب تغير صورة  من قبل %s", req.Name_ar),
			Link:  fmt.Sprintf("users/img/approve/%d", id),
		}
		_, err = h.notificationRepo.Create(n)
	}
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return h.Me(c)
}
func (h *Handler) UserUpdate(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	req := new(model.UserRegisterRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	_, err = h.userRepo.Update(uint(id), req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, "updated")
}

func (h *Handler) UserSendResetEmail(c echo.Context) error {
	const MySecret string = "abc&1*~#^2^#s0^=)^^7%b34"
	req := new(model.UserSendResetEmailRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	// encrypt the email
	encEmail, err := utils.Encrypt(req.Email, MySecret)
	if err != nil {
		fmt.Println("error encrypting your classified text: ", err)
	}
	url := fmt.Sprintf("%s?resetEmail=%s", req.Url, encEmail)
	_ = utils.SendEmail(req.Email, url)
	// fmt.Println(send)
	return c.JSON(http.StatusOK, "sent")
}

func (h *Handler) UserResetPassword(c echo.Context) error {
	const MySecret string = "abc&1*~#^2^#s0^=)^^7%b34"
	req := new(model.UserResetRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	req.Email, _ = utils.Decrypt(req.Email, MySecret)
	u, err := h.userRepo.Reset(req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	return c.JSON(http.StatusOK, u)
}

func (h *Handler) Login(c echo.Context) error {
	req := new(model.UserLoginRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}
	u, err := h.userRepo.GetByEmailOrPhone(req.Username)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}
	if u == nil {
		return c.JSON(http.StatusForbidden, "incorrect_uname")
	}

	fmt.Println(u)
	if !h.userRepo.CheckPassword(req.Password, u.Password) {
		return c.JSON(http.StatusForbidden, "wrong_password")
	}

	if err != nil {
		return c.JSON(http.StatusInternalServerError, utils.NewError(err))
	}

	return c.JSON(http.StatusOK, newUserResponse(u))
}

func newUserResponse(u *model.User) *model.UserResponse {
	r := new(model.UserResponse)
	r.User.Id = u.Id
	r.User.Name = u.Name
	r.User.Name_ar = u.Name_ar
	r.User.Email = u.Email
	r.User.Img = u.Img
	r.User.Serial = u.Serial
	r.User.Points = u.Points
	r.User.Role_id = u.Role_id
	r.User.Phone = u.Phone
	r.User.Breif = u.Breif
	r.User.Role = u.Role
	r.User.Color = u.Color
	r.User.Admin = u.Admin
	r.Token = utils.GenerateJWT(u.Id)
	return r
}

func userIDFromToken(c echo.Context) uint {
	id, ok := c.Get("user").(uint)
	if !ok {
		return 0
	}
	return id
}
