/*
Copyright 2023 Schwarz IT KG <markus.brunsch@mail.schwarz>
Copyright 2024 STACKIT GmbH & Co. KG <markus.brunsch@stackit.cloud>

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

# Upload VPN Appliance Image to OpenStack
resource "openstack_images_image_v2" "pfsense_image" {
  name             = "pfsense-2.7.2-amd64-image"
  image_source_url = "https://pfsense.object.storage.eu01.onstackit.cloud/pfsense-ce-2.7.2-amd64-10-12-2024.qcow2"
  web_download     = true
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "shared"
}
