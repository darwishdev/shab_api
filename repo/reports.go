package repo

import (
	"shab/model"

	"github.com/jinzhu/gorm"
)

type ReportsRepo struct {
	db *gorm.DB
}

func NewReportsRepo(db *gorm.DB) ReportsRepo {
	return ReportsRepo{
		db: db,
	}
}

func (ar *ReportsRepo) GetCounts() (*model.CountsResponse, error) {
	var resp model.CountsResponse
	err := ar.db.Raw("CALL FindDashboardCounts();").Row().Scan(
		&resp.Projects,
		&resp.Events,
		&resp.Users,
		&resp.PendingUsers,
		&resp.Ryadeen,
		&resp.Tamooheen,
		&resp.Mobadreen,
	)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}
