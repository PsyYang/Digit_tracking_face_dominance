compare_lmm_models <- function(data, dv, fixed_effects, random_vars, group_var) {
  
  # Create formula strings
  fixed_main <- paste(fixed_effects, collapse = " + ")
  base_formula <- paste(dv, "~", fixed_main, "+ (1 |", group_var, ")")
  
  cat("Starting model comparison process\n")
  cat("Base model:", base_formula, "\n\n")
  
  # Start with basic models testing random effects
  models <- list()
  model_formulas <- list()
  
  models[[1]] <- tryCatch({
    lmer(as.formula(base_formula), data = data, REML = FALSE)
  }, error = function(e) {
    cat("Error fitting base model:", conditionMessage(e), "\n")
    return(NULL)
  })
  
  if(is.null(models[[1]])) {
    stop("Base model failed to converge. Check your data and formula.")
  }
  
  model_formulas[[1]] <- base_formula
  
  cat("Testing random effects structures:\n")
  
  # Test random slopes for each random variable
  for(i in seq_along(random_vars)) {
    # Random slope only
    random_formula <- paste("(0 +", random_vars[i], "|", group_var, ")")
    full_formula <- paste(dv, "~", fixed_main, "+", random_formula)
    cat("- Testing random slope only:", random_formula, "\n")
    
    models[[length(models) + 1]] <- tryCatch({
      fit <- lmer(as.formula(full_formula), data = data, REML = FALSE)
      if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
      fit
    }, error = function(e) {
      cat("  Error fitting model:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    model_formulas[[length(models)]] <- full_formula
    
    # Random intercept and slope
    random_formula <- paste("(1 +", random_vars[i], "|", group_var, ")")
    full_formula <- paste(dv, "~", fixed_main, "+", random_formula)
    cat("- Testing random intercept and slope:", random_formula, "\n")
    
    models[[length(models) + 1]] <- tryCatch({
      fit <- lmer(as.formula(full_formula), data = data, REML = FALSE)
      if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
      fit
    }, error = function(e) {
      cat("  Error fitting model:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    model_formulas[[length(models)]] <- full_formula
    
    # Uncorrelated random intercept and slope
    random_formula <- paste("(1 |", group_var, ") + (0 +", random_vars[i], "|", group_var, ")")
    full_formula <- paste(dv, "~", fixed_main, "+", random_formula)
    cat("- Testing uncorrelated random intercept and slope:", random_formula, "\n")
    
    models[[length(models) + 1]] <- tryCatch({
      fit <- lmer(as.formula(full_formula), data = data, REML = FALSE)
      if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
      fit
    }, error = function(e) {
      cat("  Error fitting model:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    model_formulas[[length(models)]] <- full_formula
  }
  
  # Test combinations of random slopes if multiple random variables
  if(length(random_vars) > 1) {
    # Random slopes only
    random_formula <- paste("(0 +", paste(random_vars, collapse = " + "), "|", group_var, ")")
    full_formula <- paste(dv, "~", fixed_main, "+", random_formula)
    cat("- Testing multiple random slopes only:", random_formula, "\n")
    
    models[[length(models) + 1]] <- tryCatch({
      fit <- lmer(as.formula(full_formula), data = data, REML = FALSE)
      if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
      fit
    }, error = function(e) {
      cat("  Error fitting model:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    model_formulas[[length(models)]] <- full_formula
    
    # Random intercept and multiple slopes
    random_formula <- paste("(1 +", paste(random_vars, collapse = " + "), "|", group_var, ")")
    full_formula <- paste(dv, "~", fixed_main, "+", random_formula)
    cat("- Testing random intercept and multiple slopes:", random_formula, "\n")
    
    models[[length(models) + 1]] <- tryCatch({
      fit <- lmer(as.formula(full_formula), data = data, REML = FALSE)
      if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
      fit
    }, error = function(e) {
      cat("  Error fitting model:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    model_formulas[[length(models)]] <- full_formula
    
    # Test interaction of random slopes
    random_formula <- paste("(0 +", paste(random_vars, collapse = " * "), "|", group_var, ")")
    full_formula <- paste(dv, "~", fixed_main, "+", random_formula)
    cat("- Testing interaction of random slopes:", random_formula, "\n")
    
    models[[length(models) + 1]] <- tryCatch({
      fit <- lmer(as.formula(full_formula), data = data, REML = FALSE)
      if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
      fit
    }, error = function(e) {
      cat("  Error fitting model:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    model_formulas[[length(models)]] <- full_formula
    
    # Random intercept and interaction of random slopes
    random_formula <- paste("(1 +", paste(random_vars, collapse = " * "), "|", group_var, ")")
    full_formula <- paste(dv, "~", fixed_main, "+", random_formula)
    cat("- Testing random intercept and interaction of random slopes:", random_formula, "\n")
    
    models[[length(models) + 1]] <- tryCatch({
      fit <- lmer(as.formula(full_formula), data = data, REML = FALSE)
      if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
      fit
    }, error = function(e) {
      cat("  Error fitting model:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    model_formulas[[length(models)]] <- full_formula
  }
  
  # Remove NULL models
  valid_models <- !sapply(models, is.null)
  models <- models[valid_models]
  model_formulas <- model_formulas[valid_models]
  
  if(length(models) == 0) {
    stop("All models failed to converge. Check your data and formulas.")
  }
  
  # Select best random effects model
  best_random_idx <- 1
  for(i in 2:length(models)) {
    if(is.null(models[[i]])) next
    
    tryCatch({
      comparison <- anova(models[[i]], models[[best_random_idx]])
      p_val <- comparison$`Pr(>Chisq)`[2]
      
      if(!is.na(p_val) && p_val < 0.05) {
        best_random_idx <- i
        cat("  Model", i, "is better than current best model (p =", p_val, ")\n")
      }
    }, error = function(e) {
      cat("  Error comparing models:", conditionMessage(e), "\n\n")
    })
  }
  
  best_random_model <- models[[best_random_idx]]
  best_random_formula <- model_formulas[[best_random_idx]]
  cat("\nBest random effects structure:", best_random_formula, "\n\n")
  
  # Extract random part for future models
  random_part <- tryCatch({
    formula_parts <- as.character(formula(best_random_model))
    if(length(formula_parts) >= 3) {
      random_str <- formula_parts[3]
      if(grepl("\\(", random_str)) {
        sub(".*\\+ (\\(.*\\))", "\\1", random_str)
      } else {
        paste("(1 |", group_var, ")")
      }
    } else {
      paste("(1 |", group_var, ")")
    }
  }, error = function(e) {
    paste("(1 |", group_var, ")")
  })
  
  # Now test fixed effects interactions
  cat("Testing fixed effects interactions:\n")
  interaction_models <- list()
  interaction_formulas <- list()
  
  interaction_models[[1]] <- best_random_model
  interaction_formulas[[1]] <- best_random_formula
  
  # Test all two-way interactions
  if(length(fixed_effects) >= 2) {
    cat("\nTesting two-way interactions:\n")
    for(i in 1:(length(fixed_effects)-1)) {
      for(j in (i+1):length(fixed_effects)) {
        interaction_term <- paste(fixed_effects[i], "*", fixed_effects[j])
        other_terms <- fixed_effects[!fixed_effects %in% c(fixed_effects[i], fixed_effects[j])]
        other_terms_str <- ifelse(length(other_terms) > 0, paste("+", paste(other_terms, collapse = " + ")), "")
        
        formula_str <- paste(dv, "~", interaction_term, other_terms_str, "+", random_part)
        cat("- Testing:", interaction_term, "\n")
        
        interaction_models[[length(interaction_models) + 1]] <- tryCatch({
          fit <- lmer(as.formula(formula_str), data = data, REML = FALSE)
          if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
          fit
        }, error = function(e) {
          cat("  Error fitting model:", conditionMessage(e), "\n\n")
          return(NULL)
        })
        
        interaction_formulas[[length(interaction_models)]] <- formula_str
      }
    }
  }
  
  # Test three-way interactions
  if(length(fixed_effects) >= 3) {
    cat("\nTesting three-way interactions:\n")
    combos <- combn(fixed_effects, 3)
    for(i in 1:ncol(combos)) {
      three_terms <- combos[,i]
      interaction_term <- paste(three_terms, collapse = ":")
      
      # Keep all main effects and add the three-way interaction
      formula_str <- paste(dv, "~", fixed_main, "+", interaction_term, "+", random_part)
      cat("- Testing:", interaction_term, "\n")
      
      interaction_models[[length(interaction_models) + 1]] <- tryCatch({
        fit <- lmer(as.formula(formula_str), data = data, REML = FALSE)
        if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
        fit
      }, error = function(e) {
        cat("  Error fitting model:", conditionMessage(e), "\n\n")
        return(NULL)
      })
      
      interaction_formulas[[length(interaction_models)]] <- formula_str
    }
  }
  
  # Test four-way interactions
  if(length(fixed_effects) >= 4) {
    cat("\nTesting four-way and higher interactions:\n")
    
    # Test all possible higher-order interactions
    for(n in 4:length(fixed_effects)) {
      combos <- combn(fixed_effects, n)
      for(i in 1:ncol(combos)) {
        terms <- combos[,i]
        interaction_term <- paste(terms, collapse = ":")
        
        # Keep all main effects and add the higher-order interaction
        formula_str <- paste(dv, "~", fixed_main, "+", interaction_term, "+", random_part)
        cat("- Testing", n, "way:", interaction_term, "\n")
        
        interaction_models[[length(interaction_models) + 1]] <- tryCatch({
          fit <- lmer(as.formula(formula_str), data = data, REML = FALSE)
          if(isSingular(fit)) cat("  Warning: Singular fit detected\n\n")
          fit
        }, error = function(e) {
          cat("  Error fitting model:", conditionMessage(e), "\n\n")
          return(NULL)
        })
        
        interaction_formulas[[length(interaction_models)]] <- formula_str
      }
    }
  }
  
  # Remove NULL models
  valid_models <- !sapply(interaction_models, is.null)
  interaction_models <- interaction_models[valid_models]
  interaction_formulas <- interaction_formulas[valid_models]
  
  if(length(interaction_models) == 0) {
    stop("All interaction models failed to converge. Check your data and formulas.")
  }
  
  # Select best model using ANOVA
  best_model_idx <- 1
  for(i in 2:length(interaction_models)) {
    tryCatch({
      comparison <- anova(interaction_models[[i]], interaction_models[[best_model_idx]])
      p_val <- comparison$`Pr(>Chisq)`[2]
      
      if(!is.na(p_val) && p_val < 0.05) {
        best_model_idx <- i
        cat("  Model", i, "is better than current best model (p =", p_val, ")\n")
      }
    }, error = function(e) {
      cat("  Error comparing models:", conditionMessage(e), "\n\n")
    })
  }
  
  best_model <- interaction_models[[best_model_idx]]
  best_formula <- interaction_formulas[[best_model_idx]]
  
  cat("\n========================================\n")
  cat("BEST MODEL FORMULA:\n")
  cat(best_formula, "\n")
  cat("========================================\n")
  
  # Return only the best model
  return(best_model)
}