
from django.conf.urls import url, include
from django.contrib import admin
import views
from django.conf import settings


urlpatterns = [
    url(r'^test/$', views.test, name='test'),
    url(r'^image_upload/$', views.uploadImage, name='upload'),
    url(r'^all_activity/$', views.showActivity, name='all_activity'),
]


    

