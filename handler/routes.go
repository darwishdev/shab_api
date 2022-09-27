package handler

import (
	"shab/router/middleware"
	"shab/utils"

	"github.com/labstack/echo/v4"
)

func (h *Handler) Register(v1 *echo.Group) {
	jwtMiddleware := middleware.JWT(utils.JWTSecret)
	v1.GET("/health", h.CheckHealth)
	api := v1.Group("/api")
	api.GET("/validate", h.ValidateUser, jwtMiddleware)

	// auth routes
	auth := api.Group("/me", jwtMiddleware)
	auth.GET("", h.Me)
	auth.GET("/upgrade", h.CurrentUserUpgradeRequests)
	auth.GET("/messages", h.CurrentUserMessages)
	auth.GET("/notifications", h.CurrentUserNotifications)
	auth.PUT("", h.CurrentUserUpdate)

	// roles routes
	roles := api.Group("/roles")
	roles.PUT("/editadd/:id", h.RolesEdit)
	roles.GET("", h.RolesListAll)
	roles.GET("/:id", h.RolesFind)

	// features routes
	features := api.Group("/features")
	features.GET("", h.FeaturesListByRole)
	features.GET("/:id", h.FeaturesFindById)
	features.POST("/editadd", h.FeaturesEditAdd)
	features.PUT("/editadd/:id", h.FeaturesEditAdd)

	// admins routes
	admins := api.Group("/admins")
	admins.GET("", h.AdminsList)
	admins.POST("/excel", h.AdminsDownloadExcel)
	// users routes
	users := api.Group("/users")

	users.GET("", h.UserListByRoleOrFeatured)
	users.POST("/excel", h.UsersDownloadExcel)
	users.GET("/:id", h.UserFindById)
	users.GET("/ryadeen", h.UserListRyadeen)
	users.PUT("/editadd/:id", h.UserUpdate)
	users.POST("/editadd", h.RegisterUser)
	users.PUT("/:id", h.UserUpdate)
	users.PUT("/reset/email", h.UserSendResetEmail)
	users.PUT("/reset", h.UserResetPassword)
	users.POST("/service/:id", h.UserRequestService, jwtMiddleware)
	users.POST("/upgrade/:role", h.UserUpgrade, jwtMiddleware)

	// requests routes

	requests := api.Group("/requests")
	requests.GET("/services", h.ServicesPendingListAll)
	requests.PUT("/services/:action/:id", h.ServicesPendingAction)
	requests.GET("/services/:id", h.ServicesPendingFind)
	requests.GET("/users", h.UsersPendingListAll)
	requests.GET("/users/upgrades", h.UsersPendingUpgradeListAll)
	requests.PUT("/users/:action/:id", h.UsersPendingAction)
	requests.PUT("/upgrades/:id", h.UsersUpgradeApprove)
	requests.GET("/projects", h.ProjectsPendingListAll)
	requests.PUT("/projects/:action/:id", h.ProjectsPendingAction)
	requests.GET("/articles", h.ArticlesPendingListAll)
	requests.PUT("/articles/:action/:id", h.ArticlesPendingAction)
	requests.GET("/contacts", h.ContactsPendingListAll)

	//email routes
	//auth routes
	api.POST("/login", h.Login)
	api.POST("/register", h.RegisterUser)

	// project routes
	projects := api.Group("/projects")
	projects.GET("", h.ProjectListByCategoryUserSearch)
	projects.POST("/editadd", h.ProjectCreate, jwtMiddleware)
	projects.PUT("/editadd/:id", h.ProjectUpdate, jwtMiddleware)
	projects.GET("/:id", h.ProjectRead)
	projects.DELETE("/:id", h.ProjectDelete)

	// articles routes
	articles := api.Group("/articles")
	articles.GET("", h.ArticleListByCategoryUserSearch)
	articles.POST("/editadd", h.ArticleCreate, jwtMiddleware)
	articles.PUT("/editadd/:id", h.ArticleUpdate, jwtMiddleware)
	articles.GET("/:id", h.ArticleRead)
	articles.DELETE("/:id", h.ArticleDelete)

	// cats routes
	cats := api.Group("/categories")
	cats.GET("", h.CatsListByType)
	cats.POST("/editadd", h.CatCreate, jwtMiddleware)
	cats.PUT("/editadd/:id", h.CatUpdate, jwtMiddleware)
	cats.GET("/:id", h.CatRead)

	// cities routes
	cities := api.Group("/cities")
	cities.GET("", h.CitiesList)
	cities.POST("/editadd", h.CityCreate, jwtMiddleware)
	cities.PUT("/editadd/:id", h.CityUpdate, jwtMiddleware)
	cities.GET("/:id", h.CityRead)

	// events
	events := api.Group("/events")

	events.GET("", h.EventsListAll)
	events.GET("/:id", h.EventRead)
	events.POST("/editadd", h.EventCreate, jwtMiddleware)
	events.PUT("/editadd/:id", h.EventUpdate, jwtMiddleware)

	// services

	services := api.Group("/services")
	services.GET("", h.ServicesListAll)
	services.GET("/:id", h.ServicesFindById)
	services.POST("/editadd", h.ServiceCreate)
	services.PUT("/editadd/:id", h.ServiceUpdate)
	services.DELETE("/:id", h.ServiceDelete)
	//pages excel routes
	api.POST("/pages-home/excel", h.RichDownloadExcel)
	api.POST("/pages-roles/excel", h.RolesDownloadExcel)
	api.POST("/pages-features/excel", h.FeaturesDownloadExcel)
	api.POST("/pages-events/excel", h.EventsDownloadExcel)
	api.POST("/services/excel", h.ServicesDownloadExcel)
	api.POST("/services/excel", h.ServicesDownloadExcel)
	api.POST("/projects/excel", h.ProjectsDownloadExcel)
	api.POST("/articles/excel", h.ArticlesDownloadExcel)
	api.POST("/videos/excel", h.VideosDownloadExcel)
	api.POST("/contact/excel", h.ContactsRequestsDownloadExcel)
	api.POST("/articles-pending/excel", h.ArticleRequestsDownloadExcel)
	api.POST("/services-pending/excel", h.ServicesRequestsDownloadExcel)
	api.POST("/users-pending/excel", h.UsersRequestsDownloadExcel)
	api.POST("/users-upgrades/excel", h.UsersUpgradesDownloadExcel)
	api.POST("/projects-pending/excel", h.ProjectsRequestsDownloadExcel)

	// rich text routes
	rich := api.Group("/rich")
	rich.GET("/page", h.RichListByPage)
	rich.PUT("/:id", h.RichUpdate)
	api.GET("/rich_text/:id", h.RichGetById)
	api.PUT("/rich_text/editadd/:id", h.RichUpdate)
	rich.GET("/id/:id", h.RichGetById)
	rich.GET("", h.RichListByGroup)
	rich.GET("/key", h.RichGetByKey)

	team := api.Group("/team")
	team.GET("", h.TeamList)
	team.POST("/excel", h.TeamDownloadExcel)
	//consultunts routes
	consultunts := api.Group("/consultunts")

	consultunts.GET("", h.ConsultuntsListAll)
	consultunts.POST("/excel", h.ConsultuntsDownloadExcel)

	consultunts.POST("/editadd", h.ConsultuntsCreate)
	consultunts.PUT("/editadd/:id", h.ConsultuntsUpdate)
	// consultunts.PUT("/:id", h.ConsultuntsUpdate)
	consultunts.GET("/:id", h.ConsultuntById)

	//videos routes
	videos := api.Group("/videos")

	videos.GET("", h.VideosListByCategory)
	videos.GET("/:id", h.VideosFind)
	videos.POST("/editadd", h.VideosCreate)
	videos.PUT("/editadd/:id", h.VideosUpdate)
	videos.DELETE("/:id", h.VideosDelete)

	//msg routes
	msgs := api.Group("/chat")

	msgs.GET("", h.MsgsListAll, jwtMiddleware)
	msgs.GET("/:id", h.MsgsListByUser, jwtMiddleware)
	msgs.POST("", h.MsgsCreate, jwtMiddleware)

	// global routes

	api.GET("/counts", h.FindDashboardCounts)
	api.POST("/upload", h.Upload)
	api.POST("/delete/file", h.DeleteFile)
	api.POST("/contact", h.ContactSend)
	api.GET("/home", h.HomeGetAllData)
	api.GET("/videos", h.VideosListByCategory)
	api.GET("/cats", h.CatsListByType)
	api.GET("/cities", h.CitiesList)
	api.DELETE("/delete/:table/:id", h.DeleteRecord)

}
