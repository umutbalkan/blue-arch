class Employee

    def initialize(name, title, location, profile_url, ppic_url)
        @name = name
        @title = title
        @location = location
        @profile_url = profile_url
        @ppic_url = ppic_url
    end

    # Getters & Setters
    def set_name(name)
        @name = name
    end
    def get_name()
        return @name
    end

    def set_title(title)
        @title = title
    end
    def get_title()
        return @title
    end

    def set_loc(location)
        @location = location
    end
    def get_loc()
        return @location
    end

    def set_profile_url(url)
        @profile_url = url
    end
    def get_profile_url()
        return @profile_url
    end

    def set_ppic_url(url)
        @ppic_url = url
    end
    def get_ppic_url()
        return @ppic_url
    end
end