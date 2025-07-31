## build flygoose api
FROM golang:1.21.6-alpine3.19 AS build

COPY . /flygoose

WORKDIR /flygoose/cmd/flygoose

RUN export GOPROXY='https://goproxy.cn,direct' && go build -o /build/flygoose .

## build flygoose admin api

## build
FROM golang:1.21.6-alpine3.19 AS build2

COPY . /flygoose

WORKDIR /flygoose/cmd/admin

RUN export GOPROXY='https://goproxy.cn,direct' && go build -o /build/admin .


## deploy flygoose
FROM golang:1.21.6-alpine3.19

RUN adduser -D -u 6666 www

#copy flygoose
COPY --from=build /build/flygoose /apps/flygoose/

COPY --from=build /flygoose/cmd/flygoose/flygoose-config.yaml /apps/flygoose/

#copy flygoose admin
COPY --from=build2 /build/admin /apps/admin/

COPY --from=build2 /flygoose/cmd/admin/admin-config.yaml /apps/admin/

RUN chown -R www /apps/flygoose /apps/admin
Model(&models.Site{})  // 指定操作模型
.Where("status=?", models.SiteStatusOnline)  // 筛选在线状态站点
.Order("status desc , id desc")  // 按状态和ID降序
.Limit(1).Offset(0)  // 取第一条记录
USER www

# admin api
#CMD ["sh", "-c", "/apps/admin/admin -c /apps/admin/admin-config.yaml"]

# flygoose api
CMD ["sh", "-c", "/apps/flygoose/flygoose -c /apps/flygoose/flygoose-config.yaml"]
