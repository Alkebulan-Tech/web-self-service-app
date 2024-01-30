FROM ubuntu/nginx as builder

RUN sudo apt get install update
RUN sudo apt install git
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json
COPY gulpfile.js /usr/src/app/gulpfile.js
RUN npm install  bower
RUN npm install  gulp-cli
COPY . /usr/src/app
RUN bower --allow-root install
RUN npm install -f
RUN npm install --save-dev gulp@v3.9.1
RUN npm install --save-dev gulp-inject
RUN  npm install --save-dev gulp-ruby-sass
COPY gulpfile.js /usr/src/app/gulpfile.js
RUN gulp build  

FROM nginx:1.19.3
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
