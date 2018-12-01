# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

# Create your models here.

class ImageUpload(models.Model):
	image = models.ImageField(upload_to='uploads/%Y/%m/%d/')
	date = models.DateTimeField(auto_now_add=True, null=True)
	status = models.IntegerField(null=True)


