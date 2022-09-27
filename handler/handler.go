package handler

import (
	"shab/repo"
)

type Handler struct {
	userRepo         repo.UserRepo
	richTextRepo     repo.RichTextRepo
	roleRepo         repo.RoleRepo
	projectRepo      repo.ProjectRepo
	eventRepo        repo.EventRepo
	videoRepo        repo.VideoRepo
	articleRepo      repo.ArticleRepo
	catRepo          repo.CatRepo
	cityRepo         repo.CityRepo
	serviceRepo      repo.ServiceRepo
	consltuntsRepo   repo.ConsltuntsRepo
	notificationRepo repo.NotificationRepo
	msgRepo          repo.MsgRepo
	reportsRepo      repo.ReportsRepo
	globalRepo       repo.GlobalRepo
	requestRepo      repo.RequestRepo
}

func NewHandler(userRepo repo.UserRepo,
	richRepo repo.RichTextRepo,
	roleRepo repo.RoleRepo,
	projectRepo repo.ProjectRepo,
	eventRepo repo.EventRepo,
	videoRepo repo.VideoRepo,
	articleRepo repo.ArticleRepo,
	catRepo repo.CatRepo,
	cityRepo repo.CityRepo,
	serviceRepo repo.ServiceRepo,
	consltuntsRepo repo.ConsltuntsRepo,
	notificationRepo repo.NotificationRepo,
	msgRepo repo.MsgRepo,
	reportsRepo repo.ReportsRepo,
	globalRepo repo.GlobalRepo,
	requestRepo repo.RequestRepo,
) *Handler {
	return &Handler{
		userRepo:         userRepo,
		richTextRepo:     richRepo,
		roleRepo:         roleRepo,
		projectRepo:      projectRepo,
		eventRepo:        eventRepo,
		videoRepo:        videoRepo,
		articleRepo:      articleRepo,
		catRepo:          catRepo,
		cityRepo:         cityRepo,
		serviceRepo:      serviceRepo,
		consltuntsRepo:   consltuntsRepo,
		notificationRepo: notificationRepo,
		msgRepo:          msgRepo,
		reportsRepo:      reportsRepo,
		globalRepo:       globalRepo,
		requestRepo:      requestRepo,
	}
}
