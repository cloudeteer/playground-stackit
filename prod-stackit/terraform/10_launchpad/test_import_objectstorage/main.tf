resource "stackit_objectstorage_bucket" "clicked" {
  name       = "launchpad"
  project_id = data.stackit_resourcemanager_project.this.project_id
}

import {
  id = "${data.stackit_resourcemanager_project.this.project_id},launchpad"
  to = stackit_objectstorage_bucket.clicked
}
