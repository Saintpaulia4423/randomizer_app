// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import PreviewModal from "./preview_modal_controller"
import Randomizer from "./randomizer_controller"
import Tooltip from "./tooltip_controller"
import Info from "./info_controller"
application.register("preview_modal", PreviewModal)
application.register("randomizer", Randomizer)
application.register("tooltip", Tooltip)
application.register("info", Info)
