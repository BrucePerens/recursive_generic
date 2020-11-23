module RecursiveGeneric::Delegate
  macro delegate_but_return_self(method, to)
    def {{method}}(*args, **named_args)
      {{to}}.{{method}}(*args, **named_args)
      self
    end
  end
end
