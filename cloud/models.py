from django.db import models
from django.contrib.auth.models import User

# Create your models here.
class CloudProjectStorageItem(models.Model):
    name = models.CharField(max_length=140, null=False)
    last_modified = models.DateTimeField(auto_now=True, null=False)
    saved_data = models.TextField()
    user = models.ForeignKey(User)

    class Meta:
        db_table = u'cloud_project_storage_item'
        verbose_name_plural = "Cloud Project Storage"

    def __str__(self):
        return str(self.name)