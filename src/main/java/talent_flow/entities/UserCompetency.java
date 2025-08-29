package talent_flow.entities;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_competencies")
@IdClass(UserCompetencyId.class) // chave composta
public class UserCompetency {

    @Id
    private UUID userId;

    @Id
    private UUID competencyId;

    private Integer level;

    public UserCompetency() {/* empty */}

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public UUID getCompetencyId() {
        return competencyId;
    }

    public void setCompetencyId(UUID competencyId) {
        this.competencyId = competencyId;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }
}