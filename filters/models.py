from django.db import models

class GiseduFilters(models.Model):
    name = models.CharField(max_length=254)
    description = models.CharField(max_length=254)
    filter_type = models.CharField(max_length=254)
    data_type = models.CharField(max_length=254)
    enabled = models.BooleanField()
    option_filters = models.ManyToManyField("self", symmetrical=False, related_name="option_filters_rel", blank=True)
    exclude_filters = models.ManyToManyField("self", symmetrical=False, related_name="exclude_filters_rel", blank=True)

    class Meta:
        db_table = u'gisedu_filters'
        verbose_name_plural = "Gisedu Filters"

    def __str__(self):
        return str(self.description)


# Create your models here.
