package repo

import (
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type NotificationRepo struct {
	db *gorm.DB
}

func NewNotificationRepo(db *gorm.DB) NotificationRepo {
	return NotificationRepo{
		db: db,
	}
}

func (ur *NotificationRepo) Create(req *model.Notification) (*int, error) {

	var resp int
	err := ur.db.Raw("CALL NotificationCreate(? , ? , ?)",
		req.Title,
		req.Breif,
		req.Link,
	).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return &resp, nil
}

func (ur *NotificationRepo) ListByUserId(id int) (*[]model.Notification, error) {
	rows, err := ur.db.Raw("CALL NotificationsByUserId(?)", id).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	var resp []model.Notification
	for rows.Next() {
		var rec model.Notification
		rows.Scan(
			&rec.Title,
			&rec.Breif,
			&rec.Link,
		)
		resp = append(resp, rec)
	}
	return &resp, nil
}
