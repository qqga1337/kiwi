FROM python
RUN python3 -m ensurepip
RUN pip3 install flask psycopg2-binary
RUN mkdir -p /app/templates
EXPOSE 5000
WORKDIR /app
COPY app.py .
COPY templates/app.html ./templates
CMD flask run --host=0.0.0.0
