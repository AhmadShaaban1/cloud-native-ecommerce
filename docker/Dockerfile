FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY ./bin/cloud-native-ecommerce .
CMD ["./cloud-native-ecommerce"]
EXPOSE 8080