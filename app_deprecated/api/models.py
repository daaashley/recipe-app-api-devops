from django.db import models


# Create your models here.
class Post(models.Model):
    text = models.CharField(max_length=10000, default="", unique=False)
