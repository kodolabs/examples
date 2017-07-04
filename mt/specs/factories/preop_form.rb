FactoryGirl.define do
  factory :preop_form do
    patient
    data do
      {
        dob: '01/01/1991',
        weight: '100',
        weight_value: 'kg',
        height: '185',
        height_value: 'centimeter',
        hospitalised: 'no',
        surgical: 'no',
        medication: 'no',
        allergies: 'no',
        anaesthetic: 'no',
        mouth_neck_difficult: 'no',
        anaesthetic_problems: 'no',
        general_health: '0',
        met: '0',
        congestive_heartfailure: '0',
        dyspnoea: '0',
        angina_pectoris: '0',
        cardiac_infarct: '0',
        cardiac_arrest: '0',
        heart_catheterisation: '0',
        heart_palpitations: '0',
        heart_murmur: '0',
        hypertension: '0',
        hypercholesterolaemia: '0',
        diabetes: '0',
        stroke: '0',
        asthma: '0',
        copd_emphysema: '0',
        sleep_apnoea: '0',
        kidney_disease: '0',
        liver_disease: '0',
        weight_loss: '0',
        smoker: '0',
        alcohol_consumption: '0',
        illicit_drugs: '0'
      }
    end
  end
end
