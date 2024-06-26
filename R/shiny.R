#' Internal function that expose javascript bindings to Shiny app.
#'
#' @param libname library name
#' @param pkgname package name
#' @keywords internal
.onLoad <- function(libname, pkgname) { # nolint
  # Add directory for static resources
  file <- system.file("www", package = "shiny.semantic", mustWork = TRUE)
  shiny::addResourcePath("shiny.semantic", file)
  shiny::registerInputHandler("shiny.semantic.vector", function(value, ...) {
    if (is.null(value)) {
      return(value)
    } else {
      values <- jsonlite::fromJSON(value)
      return(values)
    }
  }, force = TRUE)
}

#' Create universal Shiny input binding
#'
#' Universal binding for Shiny input on custom user interface. Using this function one can create various inputs
#' ranging from text, numerical, date, dropdowns, etc. Value of this input is extracted via jQuery using $().val()
#' function and default exposed as serialized JSON to the Shiny server. If you want to change type of exposed input
#' value specify it via type param. Currently list of supported types is "JSON" (default) and "text".
#'
#' @param input_id String with name of this input. Access to this input within server code is normal with
#' input[[input_id]].
#' @param shiny_ui UI of HTML component presenting this input to the users. This UI should allow to extract its value
#' with jQuery $().val() function.
#' @param value An optional argument with value that should be set for this input. Can be used to store persisten input
#' valus in dynamic UIs.
#' @param type Type of input value (could be "JSON" or "text").
#' @examples
#' library(shiny)
#' library(shiny.semantic)
#' # Create a week field
#' uirender(
#'   tagList(
#'     div(class = "ui icon input",
#'         style = NULL,
#'         "",
#'         shiny_input(
#'           "my_id",
#'           tags$input(type = "week", name = "my_id", min = NULL, max = NULL),
#'           value = NULL,
#'           type = "text"),
#'         icon("calendar"))
#'   )
#' )
#'
#' @export
shiny_input <- function(input_id, shiny_ui, value = NULL, type = "JSON") {
  selected <- shiny::restoreInput(id = input_id, default = value)
  valid_types <- c("JSON", "text")

  if (!(type %in% valid_types)) {
    stop(type, " is not valid type for universal shiny input")
  }

  custom_input_class <- "shiny-custom-input"
  class <- ifelse(is.null(shiny_ui$attribs$class), "", shiny_ui$attribs$class)
  shiny_ui$attribs$class <- paste(custom_input_class, class)
  shiny_ui$attribs$id <- input_id
  shiny_ui$attribs[["data-value"]] <- selected
  shiny_ui$attribs[["data-value-type"]] <- type

  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$script(src = "shiny.semantic/shiny-custom-input.js")
      )
    ),
    shiny_ui
  )
}

#' Create universal Shiny text input binding
#'
#' Universal binding for Shiny text input on custom user interface. Value of
#' this input is extracted via jQuery using $().val() function. This function
#' is just a simple binding over shiny_input. Please take a look at shiny_input
#' documentation for more information.
#'
#' @param ... Possible arguments are the same as in shiny_input() method:
#' input_id, shiny_ui, value. Type is already predefined as "text"
#' @examples
#' library(shiny)
#' library(shiny.semantic)
#' # Create a color picker
#' uirender(
#'   tagList(
#'     div(class = "ui input",
#'         style = NULL,
#'         "Color picker",
#'         shiny_text_input(
#'           "my_id",
#'           tags$input(type = "color", name = "my_id", value = "#ff0000"))
#'     )
#'   ))
#'
#' @export
shiny_text_input <- function(...) {
  shiny_input(type = "text", ...)
}
