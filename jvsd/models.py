from django.contrib.gis.db import models

# Create your models here.
from organizations.models import GiseduOrgAddress

class GiseduJointVocationalSchoolDistrict(models.Model):
    gid = models.IntegerField(primary_key=True)
    org_key = models.IntegerField()
    jvsd_name = models.CharField(max_length=254)
    the_geom = models.PointField()
    address = models.ForeignKey(GiseduOrgAddress)
    building_irn = models.IntegerField()
    irn = models.IntegerField()
    has_atomic_learning = models.BooleanField()
    objects = models.GeoManager()

    def __str__(self):
        return self.jvsd_name

    class Meta:
        db_table = u'gisedu_joint_vocational_school_district'
