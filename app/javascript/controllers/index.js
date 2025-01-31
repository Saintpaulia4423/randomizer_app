// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import PreviewModal from "./preview_modal_controller"
import RandomSets from "./random_sets_controller"
application.register("preview_modal", PreviewModal)
application.register("random_sets", RandomSets)
