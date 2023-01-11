from django.urls import path

from .views import PostView

# from django.conf.urls.static import static
# from django.conf import settings

urlpatterns = [path("home", PostView.as_view())]
