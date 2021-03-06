#' Plot the prevalence estimates
#'
#' @param fit A rater fit object.
#'
#' @return A plot of the prevalence estimates extracted from the fit.
#'
#' @importFrom ggplot2 ggplot aes geom_bar geom_text coord_cartesian labs
#'     theme_bw
#' @importFrom rlang .data
#'
#' @noRd
#'
plot_pi <- function(fit) {
  pi <- pi_point_estimate(fit)
  plot_data <- data.frame(cat = as.factor(1:length(pi)),
                          pi = pi,
                          round_pi = round(pi, 2))

  plot <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$cat, y = .data$pi)) +
    ggplot2::geom_bar(stat = "identity", fill = "steelblue") +
    ggplot2::geom_text(ggplot2::aes(label = .data$round_pi), vjust = -3) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::labs(x = "Category",
                  y = "Prevalence prob.") +
    ggplot2::theme_bw() +
    NULL

  plot
}

#' Plot the rater accuracy estimates
#'
#' @param fit rater fit object
#' @param which which raters to plot
#'
#' @return Plot of the rate accuracy estimates
#'
#' @importFrom ggplot2 ggplot aes geom_tile geom_text facet_wrap labs guides
#'      scale_fill_gradient theme_bw theme element_rect element_blank
#' @importFrom rlang .data
#'
#' @noRd
#'
plot_theta <- function(fit, which = NULL) {
  theta <- theta_point_estimate(fit, which = which)

  # theta will always have dim[[2]] and it will always be == K
  K <- dim(theta)[[2]]

  # would be great if we could treat in arrays and matrices the 'same'
  if (length(dim(theta)) > 2) {
    J <- dim(theta)[[1]]
    value <- unlist(lapply(1:J, function(x) as.vector(theta[x, , ])))
  } else {
    J <- 1
    value <- as.vector(theta)
  }
  which <- if (is.null(which)) 1:J else which

  plot_data <- data.frame(
                  x = factor(rep(rep(1:K, each = K), J), levels = 1:K),
                  y = factor(rep(rep(1:K, K), J), levels = K:1),
                  rater = rep(which, each = K^2),
                  value = value,
                  round_value = round(value, 2))
  rownames(plot_data) <- NULL

  plot <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$x, y = .data$y)) +
   ggplot2::geom_tile(ggplot2::aes(fill = .data$value), col = "black") +
   ggplot2::geom_text(ggplot2::aes(label = .data$round_value)) +
   ggplot2::facet_wrap(~ rater) +
   # TODO add way to change defaults
   ggplot2::scale_fill_gradient(low = "white", high = "steelblue") +
   ggplot2::labs(y = "True label",
                 x = "Assigned label") +
   ggplot2::guides(fill = FALSE) +
   ggplot2::theme_bw() +
   ggplot2::theme(strip.background = ggplot2::element_rect(fill = "white"),
                  panel.grid.major = ggplot2::element_blank(),
                  panel.grid.minor = ggplot2::element_blank(),
                  panel.border     = ggplot2::element_blank()) +
   NULL

  plot
}

#' Plot the latent class estimates of a rater fit.
#'
#' @param x numeric matrix object
#' @param ... Other arguments
#'
#' @return Plot of the rate accuracy estimates
#'
#' @importFrom ggplot2 ggplot aes geom_tile geom_text labs theme_bw theme
#'     scale_fill_gradient guides element_blank
#' @importFrom rlang .data
#'
#' @noRd
#'
plot_class_probabilities <- function(fit) {

  x <- class_probabilities(fit)

  # We could validate more stringently here if required
  if (!is.numeric(x)) {
    stop("Can only plot numeric matrices.", call. = FALSE)
  }

  I <- nrow(x)
  K <- ncol(x)

  plot_data <- data.frame(x = factor(rep(1:K, each = I), levels = 1:K),
                          y = factor(rep(1:I, K), levels = I:1),
                          prob = as.vector(x),
                          round_prob = round(as.vector(x), 2))

  plot <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$x, y = .data$y)) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$prob), colour = "black") +
    ggplot2::geom_text(ggplot2::aes(label = .data$round_prob)) +
    ggplot2::labs(x = "Latent Class",
                  y = "Item") +
    ggplot2::scale_fill_gradient(low = "white", high = "steelblue") +
    ggplot2::guides(fill = FALSE) +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   panel.border     = ggplot2::element_blank()) +
    NULL

  plot
}
