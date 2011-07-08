from django.contrib.gis.db import models

class GiseduOrgType(models.Model):
    gid = models.IntegerField(primary_key=True)
    org_type_name = models.CharField(max_length=254)

    class Meta:
        db_table = u'gisedu_org_type'
        verbose_name_plural = "Educational Organization Types"



class GiseduOrgAddress(models.Model):
    gid = models.IntegerField(primary_key=True)
    street_num = models.IntegerField()
    street_name = models.CharField(max_length=254)
    mail_stop = models.CharField(max_length=254)
    address_line_one = models.CharField(max_length=254)
    address_line_two = models.CharField(max_length=254)
    city = models.CharField(max_length=254)
    state = models.CharField(max_length=254)
    zip10 = models.CharField(max_length=254)

    class Meta:
        db_table = u'gisedu_org_address'
        verbose_name_plural = "Educational Organization Addresses"



class GiseduOrg(models.Model):
    gid = models.IntegerField(primary_key=True)
    org_key = models.IntegerField()
    org_nm = models.CharField(max_length=254)
    the_geom = models.PointField()
    address = models.ForeignKey(GiseduOrgAddress)
    org_type = models.ForeignKey(GiseduOrgType)
    building_irn = models.IntegerField()
    irn = models.IntegerField()
    objects = models.GeoManager()

    class Meta:
        db_table = u'gisedu_org'
        verbose_name_plural = "Educational Organizations"

    def __str__(self):
        return str(self.org_nm)