An R package to help with simulating an investment portfolio using either historical or simulated returns. Has support for varying transactional and allocation paths.

Though the implementation gives correct results (so far as I can tell), the code is rather wretched. To make it practically usable, one would need to refactor using R's object system (R3, perhaps) and rewrite the updating procedure in some language that handles loops better (so anything other than R, basically). As I only needed it for a single project, I don't have any plans at present to continue development.

In any case, it is packaged, so you should be able to install with `devtools::install_github("ryanholbrook::investmentsim")`.
