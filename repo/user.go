package repo

import (
	"database/sql"
	"errors"
	"fmt"
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
	"golang.org/x/crypto/bcrypt"
)

type UserRepo struct {
	db *gorm.DB
}

func NewUserRepo(db *gorm.DB) UserRepo {
	return UserRepo{
		db: db,
	}
}

func (ur *UserRepo) SendMsg(req *model.MsgReq) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL MsgsCreate(? , ? , ?);",
		req.FromId,
		req.ToId,
		req.Msg,
	).Row().Scan(&resp)
	if err != nil {
		fmt.Println("error calling proc" + err.Error())
		utils.NewError(err)
		return nil, err
	}

	return &resp, nil
}
func (ur *UserRepo) Register(req *model.UserRegisterRequest) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL Register(? , ? , ? ,? , ?,? , ?);",
		req.Name,
		req.Name_ar,
		req.Email,
		req.Password,
		req.Phone,
		req.Role_id,
		req.Admin,
	).Row().Scan(&resp)
	if err != nil {
		fmt.Println("error calling proc" + err.Error())
		utils.NewError(err)
		return nil, err
	}

	return &resp, nil
}

func (ur *UserRepo) Update(Id uint, req *model.UserRegisterRequest) ([]interface{}, error) {
	rows, err := ur.db.Raw("CALL UserUpdate(? ,?, ? , ? , ? , ? , ?  , ? , ? , ? , ?);",
		Id,
		req.Name,
		req.Name_ar,
		req.Email,
		req.Password,
		req.Serial,
		req.Role_id,
		req.City_id,
		req.Img,
		req.Phone,
		req.Breif,
	).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanUserResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return result, nil
}
func (ur *UserRepo) Reset(req *model.UserResetRequest) (bool, error) {
	var resp bool
	err := ur.db.Raw("CALL UserReset(? ,?);",
		req.Email,
		req.Password,
	).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return false, err
	}

	if err != nil {
		utils.NewError(err)
		return false, err
	}

	return resp, nil
}

func (ur *UserRepo) GetNotificationsById(id uint) (*[]model.Notification, error) {
	var resp []model.Notification
	rows, err := ur.db.Raw("CALL NotificationsByUserId(?);", id).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var notification model.Notification
		rows.Scan(
			&notification.Title,
			&notification.Breif,
			&notification.Link,
		)

		resp = append(resp, notification)
	}

	return &resp, nil
}
func (ur *UserRepo) GetByEmailOrPhone(emailOrPhone string) (*model.User, error) {
	var user model.User
	fmt.Println(emailOrPhone)
	err := ur.db.Raw("CALL UserRead(?);", emailOrPhone).Row().Scan(
		&user.Id,
		&user.Admin,
		&user.Name,
		&user.Name_ar,
		&user.Email,
		&user.Img,
		&user.Serial,
		&user.Points,
		&user.Role_id,
		&user.Phone,
		&user.Breif,
		&user.Role,
		&user.Color,
		&user.Password,
	)
	// user.Img = config.Config("BASE_URL") + user.Img

	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &user, nil
}
func (ur *UserRepo) GetById(id uint) (*model.User, error) {
	var user model.User
	err := ur.db.Raw("CALL UserById(?);", id).Row().Scan(
		&user.Id,
		&user.Name,
		&user.Name_ar,
		&user.Email,
		&user.Img,
		&user.Serial,
		&user.Points,
		&user.Role_id,
		&user.Phone,
		&user.Breif,
		&user.Role,
		&user.Color,
	)
	// user.Img = config.Config("BASE_URL") + user.Img

	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &user, nil
}

func scanUserResult(rows *sql.Rows) ([]interface{}, error) {
	var resp []interface{}
	for rows.Next() {
		var rec model.User
		rows.Scan(
			&rec.Id,
			&rec.Name,
			&rec.Name_ar,
			&rec.Email,
			&rec.Img,
			&rec.Serial,
			&rec.Points,
			&rec.Role_id,
			&rec.Phone,
			&rec.Breif,
			&rec.Role,
			&rec.Color,
		)
		// rec.Img = config.Config("BASE_URL") + rec.Img

		resp = append(resp, rec)
	}

	return resp, nil
}

func (ur *UserRepo) ListAll() ([]interface{}, error) {
	rows, err := ur.db.Raw("CALL UserListByRoleOrFeatured(? , ? , ? , ? , ? , ?);", 0, 0, 0, "", "", "", "", "").Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanUserResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return result, nil
}
func (ur *UserRepo) ListByRoleOrFeatured(req *model.UserListReq) ([]interface{}, error) {
	rows, err := ur.db.Raw("CALL UserListByRoleOrFeatured(? , ? , ? ,  ? , ? , ? , ?);",
		req.Role,
		req.Featured,
		req.Admin,
		req.Name,
		req.Phone,
		req.Email,
		req.Serial,
	).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanUserResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return result, nil
}

func (ur *UserRepo) ListRyadeen() ([]interface{}, error) {
	rows, err := ur.db.Raw("CALL UserListByRoleOrFeatured(? , ?);", 3, 0).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanUserResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return result, nil
}

func (ur *UserRepo) ListFeatured() ([]interface{}, error) {
	rows, err := ur.db.Raw("CALL UserListByRoleOrFeatured(? , ?);", 0, 1).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanUserResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return result, nil
}

func (ur *UserRepo) Upgradeuser(user uint, role uint64) (bool, error) {
	ur.db.Raw("CALL UserUpgrade(? , ? );", user, role).Row()
	return true, nil
}

func (ur *UserRepo) HashUserPassword(plain string) (string, error) {
	if len(plain) == 0 {
		return "", errors.New("empty_password")
	}
	h, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	return string(h), err
}

func (ur *UserRepo) CheckPassword(plain string, password string) bool {
	// err := bcrypt.CompareHashAndPassword([]byte(password), []byte(plain))
	// return err == nil
	return plain == password
}
