{
  description = "Development environment templates";

  outputs = { self }: {
    templates = {
      starter = {
        path = ./starter;
        description = "Starter development environment template";
      };
      rust = {
        path = ./rust;
        description = "Rust development environment template";
      };
    };
    templates.default = self.templates.starter; # Optional default template
  };

}
