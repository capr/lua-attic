/* Pull-style API. Written by Cosmin Apreutesei. Same License. */

unsigned char* tls_async_send_buf(struct tls *ctx, size_t *len) {
	br_ssl_engine_context *eng = &ctx->conn->u.engine;
	return br_ssl_engine_sendrec_buf(eng, len);
}

unsigned char* tls_async_recv_buf(struct tls *ctx, size_t *len) {
	br_ssl_engine_context *eng = &ctx->conn->u.engine;
	return br_ssl_engine_sendrec_buf(eng, len);
}

void tls_async_send_ack(struct tls *ctx, size_t len) {
	br_ssl_engine_context *eng = &ctx->conn->u.engine;
	br_ssl_engine_sendrec_ack(eng, len);
}

void tls_async_recv_ack(struct tls *ctx, size_t len) {
	br_ssl_engine_context *eng = &ctx->conn->u.engine;
	br_ssl_engine_recvrec_ack(eng, len);
}

ssize_t tls_async_recv(struct tls *ctx, void *buf, size_t buflen) {
	br_ssl_engine_context *eng = &ctx->conn->u.engine;
	size_t applen;
	unsigned char *app = br_ssl_engine_recvapp_buf(eng, &applen);
	if (app == NULL)
		return -1;
	if (applen > buflen)
		applen = buflen;
	memcpy(buf, app, applen);
	br_ssl_engine_recvapp_ack(eng, applen);
	return applen;
}

ssize_t tls_async_send(struct tls *ctx, const void *buf, size_t buflen) {
	br_ssl_engine_context *eng = &ctx->conn->u.engine;
	size_t applen;
	unsigned char *app = br_ssl_engine_sendapp_buf(eng, &applen);
	if (app == NULL)
		return -1;
	if (applen > buflen)
		applen = buflen;
	memcpy(app, buf, applen);
	br_ssl_engine_sendapp_ack(eng, applen);
	br_ssl_engine_flush(eng, 0);
	return applen;
}

void tls_async_close(struct tls *ctx) {
	br_ssl_engine_context *eng = &ctx->conn->u.engine;
	br_ssl_engine_close(eng);
}

int tls_async_connected(struct tls *ctx) {
	return tls_conninfo_populate(ctx);
}
