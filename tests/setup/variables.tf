variable "name_prefix" {
  description = <<-DESCRIPTION
    Stable prefix identifying the calling test (e.g. "itbot01"). The setup
    module appends a random suffix and returns the result as `name`, which the
    test then passes to the module under test.

    Keep it short: the module's `name` validation allows at most 22 characters
    once hyphens are stripped, and the random suffix consumes 6 of them.
    DESCRIPTION
  type        = string
  nullable    = false
}
